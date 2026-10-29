*** Settings ***
Documentation    Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_Cell_BlockUnblock_on_SharedRMs_from_WebEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.robot

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AILR_B1_B2_B3_B4_B5_B6_MTNRL104_2AZQS_3AZQU_1AHPE_3AHEH
...    SBTS00   STATE_SKIP_AGENT    CRT

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USER_RTWP_CHECK}    ${TRUE}
${POWER_ON_FLAG}    ${True}
${CNI_127210_ENABLED}    ${True}

*** Test Cases ***
[1][1.0] Automated_RFS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_force_primary_link_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_RESET}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS1_RESET}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS2_RESET}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    True
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    TC__SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225


    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][5.0] Automated_RFS_SBTS_SBTS_BTS1_BTS2_Common_Startup
    [Timeout]    14400
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

[2]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][3.0] Automated_RFS_SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_common_startup_check_trm_feature_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    2
    ...    AND    Set Test Variable    ${tempRadioMasterRecovTime}    2

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    TC__SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature.TC Teardown
    ...    AND    Restore Resource Search Order

[3]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_RFS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock
     [Timeout]    14400
     [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__secondary_controller_sharedrm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_LOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${RMOD_UNLOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${LTE_IOT_check}    False

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order

[4]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][4.0] Automated_RFS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SHARED_RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    400
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[5]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_RFS_SBTS_SBTS_STATE_Secondary_Controller_SharedRM_Reset_TRM_Feature
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__secondary_controller_shared_rm_reset_trm_feature_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    2
    ...    AND    Set Test Variable    ${tempRadioMasterRecovTime}    2
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature
    TC__SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature.TC Teardown
    ...    AND    Restore Resource Search Order

[6]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_RFS_SBTS-SBTS_STATE_BTS1_BTS2_Cell_BlockUnblock_on_SharedRMs_from_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_cell_blockunblock_on_sharedrms_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_Cell_BlockUnblock_on_SharedRMs_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_Cell_BlockUnblock_on_SharedRMs_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_Cell_BlockUnblock_on_SharedRMs_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_Cell_BlockUnblock_on_SharedRMs_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_Cell_BlockUnblock_on_SharedRMs_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order

[7]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][3.0] Automated_RFS_SBTS_SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    480
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order


[8]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][2.0] Automated_RFS_SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__cm__nr_cell_timings_validation_CB008992_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    1M213449553
    ...    AND    Set Test Variable    ${NR_CELL_INDEX}    1
    ...    AND    Set Test Variable    ${timingAdvanceOffset_value}    n39936
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True

    ...    AND    SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992
    ...    AND    Set Library Search Order    SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992
    TC__SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992
    [Teardown]    Run Keywords    SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992.TC Teardown
    ...    AND    Restore Resource Search Order

[9]RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order
