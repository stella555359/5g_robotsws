*** Settings ***
Documentation    Test Suite
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__SBTS_Power_Off_On.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
&{ADD_IGNORED_ALARM_NgGnbInitFullReset}   alarmId=7115   faultId=7312
&{ADD_IGNORED_ALARM_NgGnbInitPartialReset}   alarmId=7115   faultId=7313


*** Test Cases ***
[1]UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}
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
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    5
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    None
    ...    AND    Set Test Variable    ${QC_DOMAIN}    None
    ...    AND    Set Test Variable    ${QC_ID}    None
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    None
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T03
    ...    AND    Set Test Variable    ${RDC_CONFIG}
    ...    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL55/MTNRL55_custom_rmod_setup.yaml
    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue_0
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${NR_TYPE}    NR
    ...    AND    Set Test Variable    ${LTE_TYPE}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_1
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_2
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    33 35
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
	...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_LTE_UE}    None
    ...    AND    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]UUF_ACTIVATION_RESET
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS00
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
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4700,4773,1898,6134,6132,6129,7513,7511,7509,7107
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    10
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    DU Dubai
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
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T03
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}
    ...    AND    Set Test Variable    ${RDC_CONFIG}
    ...    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL55/MTNRL55_custom_rmod_setup.yaml

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${NR_TYPE}    NR
    ...    AND    Set Test Variable    ${LTE_TYPE}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_1
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_2
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    33 35
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
	...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_LTE_UE}    None
    ...    AND    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__BBMOD_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${NR_TYPE}    NR
    ...    AND    Set Test Variable    ${LTE_TYPE}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_1
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_2
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    33 35
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
	...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_LTE_UE}    None
    ...    AND    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    35
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    35
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


[1]RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${NR_TYPE}    NR
    ...    AND    Set Test Variable    ${LTE_TYPE}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_1
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_2
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    33 35
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
	...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_LTE_UE}    None
    ...    AND    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND  Append To List  ${SBTS_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_NgGnbInitFullReset}
    ...    AND  Append To List  ${SBTS_IGNORED_ALARMS}  ${ADD_IGNORED_ALARM_NgGnbInitPartialReset}
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${HW_RESET_MAX_WAIT_TIME}    900
    ...    AND    SBTS__STATE__RM_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    TC__SBTS__STATE__RM_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RM_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${NR_TYPE}    NR
    ...    AND    Set Test Variable    ${LTE_TYPE}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_1
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_2
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    33 35
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
	...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_LTE_UE}    None
    ...    AND    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__SBTS_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__sbts_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${Objects_To_Power_Off}    SM
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_WRN_THR}    600
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_MAX_WAIT_TIME}    900
    ...    AND    SBTS__STATE__SBTS_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__SBTS_Power_Off_On
    ...    AND    Set Library Search Order    SBTS__STATE__SBTS_Power_Off_On
    TC__SBTS__STATE__SBTS_Power_Off_On
    [Teardown]    Run Keywords    SBTS__STATE__SBTS_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${NR_TYPE}    NR
    ...    AND    Set Test Variable    ${LTE_TYPE}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_1
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_2
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    33 35
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_LTE_UE}    None
    ...    AND    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${OPERATION_ORDER}    ONE_BY_ONE
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_POWER_ON_WRN_THR}    360
    ...    AND    Set Test Variable    ${HW_POWER_MAX_WAIT_TIME}    900
    ...    AND    SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Power_Off_On
    TC__SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue_6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${NR_TYPE}    NR
    ...    AND    Set Test Variable    ${LTE_TYPE}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_1
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_2
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    33 35
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
	...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_LTE_UE}    None
    ...    AND    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    510
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    510
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


[1]RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue_7
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${NR_TYPE}    NR
    ...    AND    Set Test Variable    ${LTE_TYPE}    LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_1
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_2
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    33 35
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    False
	...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_LTE_UE}    None
    ...    AND    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_SA_LTE_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order
