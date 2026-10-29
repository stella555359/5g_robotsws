*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF   CLOUD_10_18_UTESRANRFSMTNRL4
Documentation    Robot Test Suite 2
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__FHS_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot



*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables


*** Test Cases ***
[1]SBTS_SBTS__SWM__BTS1_BTS2_SWDL
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    ALL
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Teardown
    ...    AND    Restore Resource Search Order

[1]SBTS_SBTS__STATE__FHS_Reset_from_WEBEM
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__fhs_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    30

    ...    AND    SBTS_SBTS__STATE__FHS_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__FHS_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__FHS_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__FHS_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__FHS_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_CB007636_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}  ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    370
    ...    AND    Set Test Variable    ${BBMOD_RESET_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM_CB007636.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_blockunblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    290
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    REAL_ANDROID_UE_1 REAL_ANDROID_UE_2 REAL_ANDROID_UE_3 REAL_ANDROID_UE_4
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS1 BTS2 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE NR LTE
    ...    AND    Set Test Variable    ${CELLS}    10207297537;158977028;10223681540;159233025
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    REAL_ANDROID_UE_1 REAL_ANDROID_UE_3
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR NR
    ...    AND    Set Test Variable    ${CELLS}    10207297591;10223681545
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


