*** Settings ***
Documentation    Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot

Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot










Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AILR_B1_B4_B5_B6_MTNRL30_3xAZHL

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${RP_CA}  VRF_SiSo
${RP_LOCATION}  VRF_TSR2
${RP_ORGANIZATION}  VRF_TSR2_T03
${USER_RTWP_CHECK}   ${False}
&{ADD_IGNORED_ALARM_4590}    alarmId=7115    faultId=4590



*** Test Cases ***




[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS00_ENB_9999_251001_000003
    ...    AND    Set Test Variable    ${BTS2_source_sw}    SBTS00_ENB_9999_251001_000003
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS00_ENB_9999_251003_000010
    ...    AND    Set Test Variable    ${BTS2_target_sw}    SBTS00_ENB_9999_251003_000010
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    4773,1898,6134,7513,7509,1815,62003,4681,16,7509,62003
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    4773,1898,6134,7513,7509,1815,62003,4681,16,7509,62003
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4654,61524,61652,61649,4655
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4654,61524,61652,61649,4655
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}    kpi2a,kpi2b,kpi2c,kpi2d
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}    897,897,897,897
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    QCP_RAN_VRF
    ...    AND    Set Test Variable    ${QC_DOMAIN}    QCD_MN_RAN
    ...    AND    Set Test Variable    ${QC_ID}    106099
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    CLOUD_HRAN_RFS_AILR_B1_B4_B5_B6_MTNRL30_3xAZHL
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T03
    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] SW_Activation_Reset_in_loops
    [Timeout]    99600
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS00_ENB_9999_251003_000010
    ...    AND    Set Test Variable    ${BTS2_source_sw}    SBTS00_ENB_9999_251003_000010
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS00_ENB_9999_251003_000010
    ...    AND    Set Test Variable    ${BTS2_target_sw}    SBTS00_ENB_9999_251003_000010
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    4773,1898,6134,7513,7509,1815,62003,4681,16,7509,62003
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    4773,1898,6134,7513,7509,1815,62003,4681,16,7509,62003
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4654,61524,61652,61649,4655
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4654,61524,61652,61649,4655
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    4
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}    kpi2a,kpi2b,kpi2c,kpi2d
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}    897,897,897,897
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    QCP_RAN_VRF
    ...    AND    Set Test Variable    ${QC_DOMAIN}    QCD_MN_RAN
    ...    AND    Set Test Variable    ${QC_ID}    150886
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    CLOUD_HRAN_RFS_AILR_B1_B4_B5_B6_MTNRL30_3xAZHL
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T03
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_NR_SBTS__STATE__NR_RM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    Shared
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    480
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False
    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order



[1][2.0] Automated_RFS_NR_SBTS__STATE__NR_BBMOD_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    420
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIN, ABIO, ABIP
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state_rat_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    300

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order





[1]SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_blockunblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}    BTS1, BTS2
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR_LIST}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__BTS1_BTS2_Soft_RAT_Reset_from_WEBEM_BTS1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    190
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[2]SBTS_SBTS__STATE__BTS1_BTS2_Hard_RAT_Reset_from_WEBEM_BTS1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    300
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order





[1]SBTS_SBTS__STATE__SharedRM_Lock_Unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
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



[1]SBTS_SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    360
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





[1]SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__primary_controller_bbmod_reset_one_by_one.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    310
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ

    ...    AND    SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    TC__SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__primary_controller_bbmod_reset_one_by_one.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    310
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ

    ...    AND    SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    TC__SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Primary_Controller_BBMOD_Reset_one_by_one.TC Teardown
    ...    AND    Restore Resource Search Order







[1]SBTS_SBTS__STATE__BTS1_BTS2_Soft_RAT_Reset_from_WEBEM_BTS2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    230
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    230
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[2]SBTS_SBTS__STATE__BTS1_BTS2_Hard_RAT_Reset_from_WEBEM_BTS2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    300
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    310
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order






[1]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm_BTS1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_lock_unlock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${BBMOD_SN_LIST}    L1204604560, L1223402976, L1232001217, L1232004059, L1204206375, L1211704622

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.TC Teardown
    ...    AND    Restore Resource Search Order






[1]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm_BTS2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_lock_unlock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${BBMOD_SN_LIST}    L1232004059, L1204206375

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__BTS_Power_Off_On_BTS1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS_POWER_ON_WRN_THR_LIST}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214

    ...    AND  Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4590}
    ...    AND  Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_4590}
    ...    AND  Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4590}
    ...    AND  Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_4590}
    ...    AND  Remove Values From List  ${ADMIN_HISTORICAL_CRITICAL_ALARMS}  ${faultId': '4590'}

    ...    AND    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__BTS_Power_Off_On_BTS2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS_POWER_ON_WRN_THR_LIST}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214

    ...    AND  Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4590}
    ...    AND  Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_4590}
    ...    AND  Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_4590}
    ...    AND  Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_4590}

    ...    AND    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



