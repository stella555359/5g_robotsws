*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS__STATE__SM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.robot

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_ASOE_FCC_FCC_MTNRL123_1xFRMF_1xAREA    SBTS00

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USB_Byte_Protocol}  ${True}


*** Test Cases ***
[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    94400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[1]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}    ${tl.enbs[2]}
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
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4773,1898,6134,6132,6129,7513,7107,1815,4592,10,4410,4038,4401
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4773,1898,6134,6132,6129,7513,7107,1815,4592,10,4410,4038,4401
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}    4773,1898,6134,6132,6129,7513,7107,1815,4592,10,4410,4038,4401
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    verify_syslog=False
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    verify_syslog=False
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    verify_syslog=False
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    False
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    3
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
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T07
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] SW_Activation_Reset_in_loops
    [Timeout]    94400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[1]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}    ${tl.enbs[2]}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4773,1898,6134,6132,6129,7513,7107,1815,4592,10,4401,4038
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4773,1898,6134,6132,6129,7513,7107,1815,4592,10,4401,4038
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}    4773,1898,6134,6132,6129,7513,7107,1815,4592,10,4401,4038
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    verify_syslog=False
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    verify_syslog=False
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    verify_syslog=False
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    5
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
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T07
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1][3.0] Copy_of_Automated_SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts__state__sm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_TO_POWER_OFF}    ALL
    ...    AND    Set Test Variable    ${BTS1_POWER_ON_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_POWER_ON_WRN_THR}    660
    ...    AND    Set Test Variable    ${BTS3_POWER_ON_WRN_THR}    660
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS__STATE__SM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    TC__SBTS_SBTS_SBTS__STATE__SM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS__STATE__SM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order

[1][2.0] Automated_SBTS_SBTS_SBTS__STATE__Primary_Controler_SharedRM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    600
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    400
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    NokiaXR21_UE Nokia83_UE
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    LTE NR
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0 0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][4.0] Automated_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state_rat_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    300

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[2.0] Automated_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__bts_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order