*** Settings ***
Documentation  Test Suite

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AILR_B1-B4_MTNRL15_2xFRIG_2xAZNC_1xFRGU_1xFXCB_1xMDEA    SBTS00    STATE_SKIP_AGENT    CRT

Resource    ../../../test_resources/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    14400
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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    6134,6132,6129,7513,7511,7509,7107
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
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
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T06

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    SBTS_LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_UE_NR_FDD
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_UE_LTE_FDD
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    214.5 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    175.5 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    43.1 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    35.28 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    57.2 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    46.8 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    45.1 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    36.9 Mbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    SBTS_LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_UE_NR_TDD
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_UE_LTE_TDD
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    297 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    243 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    11 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    9 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    123 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    13.5 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    11.07 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_RFS_UUF_SITE_RESET_WITHOUT_HWF
    [Timeout]    18000
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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    6134,6132,6129,7513,7511,7509,7107,6327,7300,61649,4655,4654,61524
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    6134,6132,6129,7513,7511,7509,7107,6327,7300,61649,4655,4654,61524
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    10
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
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T06

    ...    AND    UUF_SITE_RESET_WITHOUT_HWF.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET_WITHOUT_HWF
    ...    AND    Set Library Search Order    UUF_SITE_RESET_WITHOUT_HWF
    TC__UUF_SITE_RESET_WITHOUT_HWF
    [Teardown]    Run Keywords    UUF_SITE_RESET_WITHOUT_HWF.TC Teardown
    ...    AND    Restore Resource Search Order


[3]RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    SBTS_LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_UE_NR_FDD
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_UE_LTE_FDD
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    214.5 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    175 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    43.1 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    35.28 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    57.2 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    46.8 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    45.1 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    36.9 Mbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[4]RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    SBTS_LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_UE_NR_TDD
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_UE_LTE_TDD
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    297 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    243 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    11 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    9 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    123 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    13.5 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    11.07 Mbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFSplit_SBTS__STATE__Radio_module_Power_OFF_ON
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${OPERATION_ORDER}    ONE_BY_ONE
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${HW_POWER_MAX_WAIT_TIME}    900

    ...    AND    SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Power_Off_On
    TC__SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[7]RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    SBTS_LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_UE_NR_FDD
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_UE_LTE_FDD
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    214.5 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    175.5 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    43.1 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    35.28 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    57.2 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    46.8 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    45.1 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    36.9 Mbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[8]RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${SLAVE_TECHNO_UE2}    SBTS_LTE
    ...    AND    Set Test Variable    ${NR_UE_CAPABILITIES}    REAL_ANDROID_UE_NR_TDD
    ...    AND    Set Test Variable    ${LTE_UE_CAPABILITIES}    REAL_ANDROID_UE_LTE_TDD
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CELLS_LIST_LTE_UE}    DEFAULT
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_LTE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_LTE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_UE}    297 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_UE}    243 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_UE}    11 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_UE}    9 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_LTE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_LTE_UE}    123 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_LTE_UE}    13.5 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_LTE_UE}    11.07 Mbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_LTE_Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order
