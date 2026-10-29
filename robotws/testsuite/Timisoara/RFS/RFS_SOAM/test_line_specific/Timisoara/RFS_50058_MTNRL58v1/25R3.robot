*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.robot
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.robot

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AILR_B1-6_MTNRL58_3AHCA_3UHFA_2UHIE_1AHEGG
...    SBTS00   STATE_SKIP_AGENT    CRT

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}  ${True}
${POWER_ON_FLAG}    ${True}
${custom_allowed_alarms}    4773,1815,7300,7513,7511,7509,7308,62003,6134,1994,8150,6351,4694,4764
${USB_Byte_Protocol}  ${True}
&{IGNORE_FAULT_1994}   alarmId=7115    faultId=1994

*** Test Cases ***
[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    20400
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
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    ${custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    ${custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    verify_syslog=${False}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    verify_syslog=${False}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
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
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    QCP_RAN_VRF
    ...    AND    Set Test Variable    ${QC_DOMAIN}    QCD_MN_RAN
    ...    AND    Set Test Variable    ${QC_ID}    72711
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    CLOUD_HRAN_RFS_AILR_B1-6_MTNRL58_3AHCA_3UHFA_2UHIE_1AHEGG
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T02
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] SW_Activation_Reset_in_loops
    [Timeout]    20400
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
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    ${custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    ${custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    verify_syslog=${False}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    verify_syslog=${False}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    5
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}    kpi1a
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}    600
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    QCP_RAN_VRF
    ...    AND    Set Test Variable    ${QC_DOMAIN}    QCD_MN_RAN
    ...    AND    Set Test Variable    ${QC_ID}    72712
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    CLOUD_HRAN_RFS_AILR_B1-6_MTNRL58_3AHCA_3UHFA_2UHIE_1AHEGG
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T02
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    NR_UE
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    LTE_UE
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    10208182282 158990853
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    158990850
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][2.0] Automated_RFS_NRL__STATE__Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__common_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_WRN_THR}    600
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900
	...    AND    Append To List  ${test_alarms_list}[MASTER_IGNORED_ALARMS_CNI_127210]  ${IGNORE_FAULT_1994}
	...    AND    Append To List  ${test_alarms_list}[MASTER_IGNORED_ALARMS_NO_CNI_127210]  ${IGNORE_FAULT_1994}
	...    AND    Append To List  ${test_alarms_list}[SLAVE_IGNORED_ALARMS_CNI_127210]  ${IGNORE_FAULT_1994}
	...    AND    Append To List  ${test_alarms_list}[SLAVE_IGNORED_ALARMS_NO_CNI_127210]  ${IGNORE_FAULT_1994}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Teardown
    ...    AND    Restore Resource Search Order

