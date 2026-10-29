*** Settings ***
Documentation    Testsuite
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/UUF_ACTIVATION_RESET.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/RRM__RFS__Data_Transfer_Taf_Ue.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USB_Byte_Protocol}  ${True}
&{ADD_IGNORED_ALARM_DSS}   alarmId=7114   faultId=7513
&{ADD_IGNORED_ALARM_DSS2}   alarmId=7114   faultId=7509
&{ADD_IGNORED_ALARM_PPS}   alarmId=7108   faultId=1898
&{ADD_IGNORED_ALARM_Phase}   alarmId=7114   faultId=4452
&{ADD_IGNORED_ALARM_XP}   alarmId=7107   faultId=62003


*** Test Cases ***
[1]UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    72h
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.gnbs[1]}
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
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    4334
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4452,4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1898,4592,4334
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4452,4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1898,4592,4334
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    3
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
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T03
    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Data_Transfer_Taf_Ue_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Data_Transfer_Taf_Ue_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS2
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]UUF_ACTIVATION_RESET_1
    [Timeout]    94400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.gnbs[1]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}    4334
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4452,4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1898,4592,4334
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4452,4700,4773,1898,6134,6132,6129,7513,7511,7509,7107,1898,4592,4334
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
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR_T03
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_ACTIVATION_RESET.TC Setup
    ...    AND    Modify Resource Search Order    UUF_ACTIVATION_RESET
    ...    AND    Set Library Search Order    UUF_ACTIVATION_RESET
    TC__UUF_ACTIVATION_RESET
    [Teardown]    Run Keywords    UUF_ACTIVATION_RESET.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Data_Transfer_Taf_Ue_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Data_Transfer_Taf_Ue_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS2
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}   450
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Data_Transfer_Taf_Ue_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Data_Transfer_Taf_Ue_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS2
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]NR_NR__STATE__NR_RM_Reset_from_WEBEM
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Data_Transfer_Taf_Ue_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Data_Transfer_Taf_Ue_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS2
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]NR_NR__STATE__NR_RM_LockUnlock_from_WEBEM
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


[1]RRM__RFS__Data_Transfer_Taf_Ue_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Data_Transfer_Taf_Ue_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS2
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1]NR_NR__STATE__BTS1_BTS2_Startup
    [Timeout]    94400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__common_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SBTS_POWER_ON_WRN_THR}    600
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Teardown
    ...    AND    Restore Resource Search Order

[1]RRM__RFS__Data_Transfer_Taf_Ue_6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Data_Transfer_Taf_Ue_6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS2
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order