*** Settings ***
Documentation    Robot Test Suite

Force tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00   CLOUD_HRAN_RFS_AILR_B1-2_AIR_B4_MTNRL8_2xAENB

Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/SBTS_SBTS__CM__RMOD_Sync_change_CB007963.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__LOGS__Stability.robot



*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}
${CNI_127210_ENABLED}    ${True}
${USER_STOP_AND_FIX}    ${True}
${USER_STOP_AND_FIX_BLOCK_TEST}    ${False}
${custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,4530,10,1815,4452,16


*** Test Cases ***
[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    36000
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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    ${custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    ${custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}
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
    ...    AND    Set Test Variable    ${QC_PROJECT}    ${None}
    ...    AND    Set Test Variable    ${QC_DOMAIN}    ${None}
    ...    AND    Set Test Variable    ${QC_ID}    ${None}
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    ${None}
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T02
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}
    ...    AND    Set Test Variable    ${RDC_CONFIG}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL8/MTNRL8_custom_rmod_setup.yaml

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order




# UUF Site Reset test
[1][1.0] SW_Activation_Reset_in_loops
    [Timeout]    24400
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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    ${custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    ${custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}
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
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T02
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}
    ...    AND    Set Test Variable    ${RDC_CONFIG}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL8/MTNRL8_custom_rmod_setup.yaml
    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__cm__rmod_sync_change_CB007963_alarms_definitions.py
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS1}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL8/CB007963/node1_26R1.xml
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS2}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL8/CB007963/node2_26R1.xml
    ...    AND    Set Test Variable    ${RMOD_WITH_SyncResiliency}    1M222721535
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3

    ...    AND    SBTS_SBTS__CM__RMOD_Sync_change_CB007963.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    ...    AND    Set Library Search Order    SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    TC__SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    [Teardown]    Run Keywords    SBTS_SBTS__CM__RMOD_Sync_change_CB007963.TC Teardown
    ...    AND    Restore Resource Search Order

[2][2.0] Automated_RFS_SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__cm__rmod_sync_change_CB007963_alarms_definitions.py
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS1}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL8/CB007963/node1_26R1.xml
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS2}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL8/CB007963/node2_26R1.xml
    ...    AND    Set Test Variable    ${RMOD_WITH_SyncResiliency}    1M222721563
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3

    ...    AND    SBTS_SBTS__CM__RMOD_Sync_change_CB007963.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    ...    AND    Set Library Search Order    SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    TC__SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    [Teardown]    Run Keywords    SBTS_SBTS__CM__RMOD_Sync_change_CB007963.TC Teardown
    ...    AND    Restore Resource Search Order

[3][2.0] Automated_RFS_SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__cm__rmod_sync_change_CB007963_alarms_definitions.py
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS1}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL8/CB007963/node1_26R1.xml
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS2}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL8/CB007963/node2_26R1.xml
    ...    AND    Set Test Variable    ${RMOD_WITH_SyncResiliency}    1M222721520
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3

    ...    AND    SBTS_SBTS__CM__RMOD_Sync_change_CB007963.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    ...    AND    Set Library Search Order    SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    TC__SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    [Teardown]    Run Keywords    SBTS_SBTS__CM__RMOD_Sync_change_CB007963.TC Teardown
    ...    AND    Restore Resource Search Order