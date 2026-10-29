*** Settings ***
Documentation    Robot Test Suite

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AIR_B4_AILR_B4_B5_MTNRL90_3xFHFB_3xAHFIB_1xMDEA    SBTS00

Resource    ../../../test_resources/NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config.robot
Resource    ../../../test_resources/NR_SBTS__STATE__PrimaryController_SharedFHS_Reset.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/NR_SBTS__STATE__SBTS_Site_Reset_from_WEBEM_with_sharedFHS_config.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
&{ADD_IGNORED_ALARM_61652}   alarmId=7220   faultId=61652
&{ADD_IGNORED_ALARM_8150}   alarmId=7115   faultId=8150
${CNI_127210_ENABLED}    ${True}


*** Test Cases ***

[1][2.0] Automated_RFS_SBTS_SBTS__SWM__BTS1_BTS2_SWDL
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    ALL
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    606
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    False
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][2.0] Automated_RFS_NR_SBTS__STATE__SBTS_Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_sbts__state__sbts_site_reset_from_webem_with_sharedFHS_config_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SBTS_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${SBTS_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Append To List  ${NR_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${NR_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    NR_SBTS__STATE__SBTS_Site_Reset_from_WEBEM_with_sharedFHS_config.TC Setup
    ...    AND    Modify Resource Search Order    NR_SBTS__STATE__SBTS_Site_Reset_from_WEBEM_with_sharedFHS_config
    ...    AND    Set Library Search Order    NR_SBTS__STATE__SBTS_Site_Reset_from_WEBEM_with_sharedFHS_config
    TC__NR_SBTS__STATE__SBTS_Site_Reset_from_WEBEM_with_sharedFHS_config
    [Teardown]    Run Keywords    NR_SBTS__STATE__SBTS_Site_Reset_from_WEBEM_with_sharedFHS_config.TC Teardown
    ...    AND    Restore Resource Search Order


[3]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_sbts__state__nr_bts_block_unblock_from_webem_with_sharedfhs_config_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Append To List  ${NR_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${NR_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config.TC Setup
    ...    AND    Modify Resource Search Order    NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config
    ...    AND    Set Library Search Order    NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config
    TC__NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config
    [Teardown]    Run Keywords    NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config.TC Teardown
    ...    AND    Restore Resource Search Order

[4]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_NR_SBTS__STATE__SBTS_Cell_BlockUnblock_from_WEBEM_LTE_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${RAT_LIST}    LTE
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    14
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    14
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[5]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_NR_SBTS__STATE__SBTS_Cell_BlockUnblock_from_WEBEM_WCDMA_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${RAT_LIST}    WCDMA
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    14
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    14
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[6]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_NR_SBTS__STATE__SBTS_Cell_BlockUnblock_from_WEBEM_GSM_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${RAT_LIST}    GSM
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    14
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    14
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[7]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_NR_SBTS__STATE__NR_Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${RAT_LIST}    NR
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    14
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    14
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[8]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_NR_SBTS__STATE__SBTS_RM_Reset_from_WEBEM_SharedRM
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
    ...    AND    Set Test Variable    ${SKIP_KPI_CALCULATION}    ${True}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}


    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order


[9]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_NR_SBTS_STATE_SharedFHS_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_sbts__state__primary_controller_sharedFHS_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${FHS_RESET_WRN_THR}    290
    ...    AND    Append To List  ${NR_IGNORED_ALARMS_CNI_127210}  ${ADD_IGNORED_ALARM_8150}
    ...    AND    Append To List  ${NR_IGNORED_ALARMS_NO_CNI_127210}  ${ADD_IGNORED_ALARM_8150}

    ...    AND    NR_SBTS__STATE__PrimaryController_SharedFHS_Reset.TC Setup
    ...    AND    Modify Resource Search Order    NR_SBTS__STATE__PrimaryController_SharedFHS_Reset
    ...    AND    Set Library Search Order    NR_SBTS__STATE__PrimaryController_SharedFHS_Reset
    TC__NR_SBTS__STATE__PrimaryController_SharedFHS_Reset
    [Teardown]    Run Keywords    NR_SBTS__STATE__PrimaryController_SharedFHS_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[10]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



[1]NR_SBTS__STATE__NR_BBMOD_Reset_from_WEBEM_with_sharedFHS_config
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



[11]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE BTS2_WCDMA BTS2_GSM
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE WCDMA GSM
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;10900 10901 10902
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



