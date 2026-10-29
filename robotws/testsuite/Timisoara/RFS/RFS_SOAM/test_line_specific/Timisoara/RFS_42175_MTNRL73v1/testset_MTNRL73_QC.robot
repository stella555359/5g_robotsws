*** Settings ***
Documentation    Test Suite
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AILR_B1-1_MTNRL73_3xAZNA    SBTS25R3    STATE_SKIP_AGENT    CRT
Resource    ../../../test_resources/RRM__RFS__Data_Transfer_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/SBTS_SBTS__SWM__SW_Fallback.robot
Resource    ../../../test_resources/SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BBMOD_Reset_CB010846.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}    ${True}
&{ADD_IGNORED_ALARM_4003}    alarmId=7115    faultId=4003
&{ADD_IGNORED_ALARM_7513}    alarmId=7114    faultId=7513
&{ADD_IGNORED_ALARM_6134}    alarmId=7115    faultId=6134
${USER_RSI_INFO_COLLECT}  True
${USB_Byte_Protocol}    ${True}


*** Test Cases ***
[1][1.0] Automated_RFS_SBTS_SBTS_STATE_Checking_mandatory_parameter_converted_to_optional_CB013033
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__checking_mandatory_parameter_converted_to_optional_CB013033.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${RAT_LIST}    NR
    ...    AND    SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033
    TC__SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Checking_mandatory_parameter_converted_to_optional_CB013033.TC Teardown
    ...    AND    Restore Resource Search Order



[27][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_4
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

[28][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_3
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

[1]SBTS_SBTS__SWM__SW_Fallback
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BOTH
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_BTS1
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS1_reset_number}    1
    ...    AND    Set Test Variable    ${BTS2_reset_number}    0
    ...    AND    Set Test Variable    ${swFallbackTimer}    30
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    BTS1-M73-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m73
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    BTS1-M73-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m73
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.21
    ...    AND    Set Test Variable    ${BTS2_EIF_down}    BTS2-M73-EIF-down
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}    EIF-down-m73
    ...    AND    Set Test Variable    ${BTS2_EIF_up}    BTS2-M73-EIF-up
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}    EIF-up-m73
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}    10.255.10.21
    ...    AND    SBTS_SBTS__SWM__SW_Fallback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback
    TC__SBTS_SBTS__SWM__SW_Fallback
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__swm__sw_fallback_with_cold_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Fallback}    BOTH
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_BTS1
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${BTS1_EIF_down}    BTS1-M73-EIF-down
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_down}    EIF-down-m73
    ...    AND    Set Test Variable    ${BTS1_EIF_up}    BTS1-M73-EIF-up
    ...    AND    Set Test Variable    ${BTS1_EIF_pass_up}    EIF-up-m73
    ...    AND    Set Test Variable    ${BTS1_EIF_Switch_IpAddress}    10.255.10.21
    ...    AND    Set Test Variable    ${BTS2_EIF_down}    BTS2-M73-EIF-down
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_down}    EIF-down-m73
    ...    AND    Set Test Variable    ${BTS2_EIF_up}    BTS2-M73-EIF-up
    ...    AND    Set Test Variable    ${BTS2_EIF_pass_up}    EIF-up-m73
    ...    AND    Set Test Variable    ${BTS2_EIF_Switch_IpAddress}    10.255.10.21
    ...    AND    SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset
    ...    AND    Set Library Search Order    SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset
    TC__SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset
    [Teardown]    Run Keywords    SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_3
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


[2][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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


[1][3.0] Automated_RFS_SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_blockunblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
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

[1][4.0] Automated_RFS_SBTS_SBTS_BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_lock_unlock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_SN_LIST}

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.TC Teardown
    ...    AND    Restore Resource Search Order



[3][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[4][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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




[1][3.0] Automated_RFS_SBTS_SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Append To List  ${test_alarms_list}[MASTER_IGNORED_ALARMS_CNI_127210]  ${ADD_IGNORED_ALARM_4003}
    ...    AND    Append To List  ${test_alarms_list}[SLAVE_IGNORED_ALARMS_CNI_127210]  ${ADD_IGNORED_ALARM_4003}
    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order




[7][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[8][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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


[1][4.0] Automated_RFS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${SHARED_RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    240
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Append To List  ${test_alarms_list}[MASTER_IGNORED_ALARMS_CNI_127210]  ${ADD_IGNORED_ALARM_4003}
    ...    AND    Append To List  ${test_alarms_list}[SLAVE_IGNORED_ALARMS_CNI_127210]  ${ADD_IGNORED_ALARM_4003}
    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order


[9][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[10][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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

[1][2.0] Automated_RFS_SBTS_SBTS__STATE__BTS_secondary_controller_POWER_OFF_ON
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS_POWER_ON_WRN_THR_LIST}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[5][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[6][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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



[1][2.0] Automated_RFS_SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM_Hard
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    270
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



[11][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[12][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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


[1][2.0] Automated_RFS_SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__smod_bbmod_shared_rm_secondary_link_is_lost.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${RMOD_SN_list}    EA213356580, EA203458569, EA203458483
    ...    AND    Set Test Variable    ${RM_MAX_WAIT_TIME_Link_Restore}    120
    ...    AND    SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost
    TC__SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Secondary_link_is_lost.TC Teardown
    ...    AND    Restore Resource Search Order


[13][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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

[14][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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


[1][2.0] Automated_RFS_SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__smod_bbmod_shared_rm_primary_link_is_lost.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SN_list}    ALL
    ...    AND    Set Test Variable    ${RM_MAX_WAIT_TIME_Link_Break}    240
    ...    AND    Set Test Variable    ${RM_MAX_WAIT_TIME_Link_Restore}    120
    ...    AND    SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost
    TC__SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__SMOD_BBMOD_shared_RM_Primary_link_is_lost.TC Teardown
    ...    AND    Restore Resource Search Order


[15][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[16][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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

[1][3.0] Automated_RFS_SBTS_SBTS__STATE__RM_Power_Off_On
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

[17][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[18][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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

[1][3.0] Automated_RFS_SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${ACTIVATE_CB010846}    ${False}
    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime}    300
    ...    AND    Set Test Variable    ${EXCEPTED_FROM_CB007447_RMOD_SN}
    ...    AND    Set Test Variable    ${EXCEPTED_FROM_CB010846_RMOD_SN}
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order

[19][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[20][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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

[1][3.0] Automated_RFS_SBTS_SBTS__STATE__BTS_primary_controller_POWER_OFF_ON
    [Timeout]    50000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS_POWER_ON_WRN_THR_LIST}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    False
    ...    AND    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order

[21][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[22][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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

[1][1.0] Automated_RFS_SBTS_SBTS__STATE__BBMOD_Reset_from_WEBEM_CB010846
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_reset_cb010846_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime}    420
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${NOT_ALLOWED_RESET_BBMOD_LIST}
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    SBTS_SBTS__STATE__BBMOD_Reset_CB010846.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_Reset_CB010846
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_Reset_CB010846
    TC__SBTS_SBTS__STATE__BBMOD_Reset_CB010846
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_Reset_CB010846.TC Teardown
    ...    AND    Restore Resource Search Order

[2][1.0] Automated_RFS_SBTS_SBTS__STATE__BBMOD_Reset_from_WEBEM_CB010846
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bbmod_reset_cb010846_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime}    420
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${NOT_ALLOWED_RESET_BBMOD_LIST}
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    SBTS_SBTS__STATE__BBMOD_Reset_CB010846.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BBMOD_Reset_CB010846
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BBMOD_Reset_CB010846
    TC__SBTS_SBTS__STATE__BBMOD_Reset_CB010846
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BBMOD_Reset_CB010846.TC Teardown
    ...    AND    Restore Resource Search Order

[23][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[24][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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

[1][1.0] Automated_RFS_SBTS_SBTS__STATE__Primary_Controller_RM_Lock_Unlock
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
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

[2][1.0] Automated_RFS_SBTS_SBTS__STATE__Primary_Controller_RM_Lock_Unlock
    [Timeout]    40000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
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

[25][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
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


[26][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    400 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
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

[1][2.0] Automated_RFSplit_SBTS__CM__Planned_Recommissioning_template
   [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__cm__planned_recommissioning_template_alarms_definitions.py
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS1}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL73/SCF_c40732_deleted.xml
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

[1]SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
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
