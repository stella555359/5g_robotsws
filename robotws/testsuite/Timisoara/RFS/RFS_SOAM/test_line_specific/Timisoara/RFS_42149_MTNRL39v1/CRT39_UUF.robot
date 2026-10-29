*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/RRM__RFS__Data_Transfer_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot


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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    10,1815,4773,1898,4592,7300,7319
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}    10,1815,4773,1898,4592,7300,7319
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4655,61649,4654,61524,61652
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4655,61524,4654,61652,61649
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
    ...    AND    Set Test Variable    ${SW_BUILD}    None
    ...    AND    Set Test Variable    ${TOPOLOGY}    None
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T06

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    10207870981 10207870980 10207870978 10207870977 158985985 158985989 158985988
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    500 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    700 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]UUF_SITE_RESET_WITHOUT_HWF
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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    10,1815,4592,1898,7319,7300
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}    10,1815,4592,1898,7319,7300
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4655,61649,4654,61524,61652
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4655,61649,4654,61524,61652
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
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
    ...    AND    Set Test Variable    ${SW_BUILD}    None
    ...    AND    Set Test Variable    ${TOPOLOGY}    None
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T06

    ...    AND    UUF_SITE_RESET_WITHOUT_HWF.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET_WITHOUT_HWF
    ...    AND    Set Library Search Order    UUF_SITE_RESET_WITHOUT_HWF
    TC__UUF_SITE_RESET_WITHOUT_HWF
    [Teardown]    Run Keywords    UUF_SITE_RESET_WITHOUT_HWF.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    10207870981 10207870980 10207870978 10207870977 158985985 158985989 158985988
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    500 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    700 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__SharedRM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False
    ...    AND    Set Test Variable    ${LTE_IOT_check}    False

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order


[3]RRM__RFS__Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    10207870981 10207870980 10207870978 10207870977 158985985 158985989 158985988
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    1500 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    500 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    700 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order
